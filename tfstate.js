const fs = require('fs')

const machines = ['[nginx]', null, '[all:vars]']

let config = {
    'blue:vars': {

        app_version: 'latest',
        host: 'blue.lostcities.dev',
        nomad_join: 'red.lostcities.dev',
        box: 'blue'

    },
    'white:vars': {
        app_version: 'latest',
        host: 'white.lostcities.dev',
        nomad_join: 'red.lostcities.dev',
        box: 'white'

    },
    'red:vars':  {
        app_version: 'latest',
        host: 'red.lostcities.dev',
        nomad_join: 'blue.lostcities.dev',
        box: 'red'
    },
    'yellow:vars': {
        app_version: 'latest',
        host: 'yellow.lostcities.dev',
        nomad_join: 'blue.lostcities.dev',
        box: 'yellow'
    },
    'green:vars': {
        app_version: 'latest',
        host: 'green.lostcities.dev',
        nomad_join: 'blue.lostcities.dev',
        box: 'green'
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

            machines.push(`${service.name}_ipv4=${service.ipv4_address}`)

            return [
                `[${service.name}]`,
                service.ipv4_address,
                '',
                `[${service.name}:vars]`,
                `ipv4_address=${service.ipv4_address}`,
                ...Object.keys(vars).map(key => `${key}=${vars[key]}`)
            ].join('\n')
        })).flat()



    console.log([machines.join('\n'), ...inventory].join('\n\n'))
} catch (err) {
    console.error(err)
}



