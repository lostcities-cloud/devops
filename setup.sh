export ANSIBLE_HOST_KEY_CHECKING=false

mkdir -p "./build"

retries=5
parse_args() {
    case "$1" in
        -rebuild)
            terraform destroy -auto-approve
            ;;
    esac
}

function apply_terraform(){
  cd ./initialize || exit;

  n=0
  until [ "$n" -ge $retries ]
  do
     terraform apply -auto-approve && break
     n=$((n+1))
  done
  cd ..
}

function apply_ansible() {
  ansible-playbook ./provision/base-configure.yml -i ./build/inventory.ini
  ansible-playbook ./provision/frontend-configure.yml -i ./build/inventory.ini
  ansible-playbook ./provision/nginx.yml -i ./build/inventory.ini
}

apply_terraform
node tfstate.js ./initialize/terraform.tfstate > ./build/inventory.ini
apply_ansible
