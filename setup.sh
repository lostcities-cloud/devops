export ANSIBLE_HOST_KEY_CHECKING=false

DOMAIN="lostcities.dev"

function terraform_retry(){
  cd ./initialize || exit;

  retries=5
  n=0
  until [ "$n" -ge $retries ]
  do
     terraform apply -var="domain=${DOMAIN}" -auto-approve && break
     n=$((n+1))
  done
  cd ..
}

function ansible_retry() {
  retries=2
  n=0
  until [ "$n" -ge $retries ]
  do
    ansible-playbook "${@: 1}" -i ./inventory.ini --extra-vars "domain=${DOMAIN}"  && break
    n=$((n+1))
  done
}

while [[ $# -gt 0 ]]; do
  case $1 in
    -n|-domain)
      DOMAIN="$2"
      shift; shift;
      ;;
    -d|-destroy)
      echo "Destroying..."
      #ansible_retry ./provision/nomad/nomad-stop.yml || true
      cd ./initialize || exit;
      terraform destroy -var="domain=${DOMAIN}" -auto-approve
      cd ..;
      shift
      ;;
    -nuke)
      echo "Destroying..."
      #ansible_retry ./provision/nomad/nomad-stop.yml  || true
      cd ./initialize || exit;
      terraform destroy -var="domain=${DOMAIN}" -auto-approve
      exit;
      ;;
    -*)
      echo "Unknown option $1"
      exit 1
      ;;
    *)
      POSITIONAL_ARGS+=("$1") # save positional arg
      shift # past argument
      ;;
  esac
done

echo "Deploying to host ${DOMAIN}"

terraform_retry

node tfstate.js ./initialize/terraform.tfstate > ./inventory.ini

#ansible_retry ./provision/full-provision-playbook.yml
ansible_retry ./provision/systemd-resolved/systemd-resolved-playbook.yml
#ansible_retry ./provision/frontend-playbook.yml
#
#ansible_retry ./provision/docker/docker-playbook.yml
#
#ansible_retry ./provision/consul/consul-install.yml
#ansible_retry ./provision/consul/consul-client.yml
#ansible_retry ./provision/consul/consul-join.yml
#
#ansible_retry ./provision/nomad/nomad-ports.yml
#ansible_retry ./provision/nomad/nomad-client.yml



# ansible_retry ./provision/nginx/nginx-playbook.yml --extra-vars "domain=${DOMAIN}"
# ansible_retry ./provision/prometheus/prometheus-playbook.yml
