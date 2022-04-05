const fs = require('fs')

const machines = ['[nginx]', null, '[nginx:vars]']

let config = {
    'blue:vars': {
        app_name: 'lostcities-accounts',
        app_version: 'latest'
    },
    'red:vars':  {
        app_name: 'lostcities-matches',
        app_version: 'latest'
    },
    'yellow:vars': {
        app_name: 'lostcities-gamestate',
        app_version: 'latest'
    },
    'green:vars': {
        app_name: 'lostcities-player-events',
        app_version: 'latest'
    }
}

try {
    const state = JSON.parse(
        fs.readFileSync(process.argv[2], 'utf8')
    );

    let inventory = state.resources
        .filter(resource => resource.type === "digitalocean_droplet")
        .map(resource => resource.instances).flat()
        .map(instance => {
            return { "name": instance.attributes.tags[0], "ipv4_address": instance.attributes.ipv4_address }
        }).map((service => {
            let vars = config[`${service.name}:vars`]

            if(service.name === 'blue') {
                machines.splice(1, 0, service.ipv4_address)
            }

            machines.push(`${service.name}=${service.ipv4_address}`)

            return [
                `[${service.name}]`,
                service.ipv4_address,
                '',
                `[${service.name}:vars]`,
                ...Object.keys(vars).map(key => `${key}=${vars[key]}`)
            ].join('\n')
        })).flat()



    console.log([machines.join('\n'), ...inventory].join('\n\n'))
} catch (err) {
    console.error(err)
}



