export ANSIBLE_HOST_KEY_CHECKING=false

DOMAIN="lostcities.dev"

function terraform_retry(){
  cd ./terraform || exit;

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

      cd ./terraform || exit;
      terraform destroy -var="domain=${DOMAIN}" -auto-approve
      cd ..;
      shift
      ;;
    -nuke)
      echo "Destroying..."

      cd ./terraform || exit;
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

node tfstate.js ./terraform/terraform.tfstate > ./inventory.ini

ansible_retry ./ansible/full-provision-playbook.yml

nomad job run ./nomad/accounts.hcl
nomad job run ./nomad/gamestate.hcl
nomad job run ./nomad/matches.hcl
nomad job run ./nomad/player-events.hcl
nomad job run ./nomad/prometheus.hcl
nomad job run ./nomad/vector.hcl
nomad job run ./nomad/nginx.hcl
nomad job run ./nomad/loki.hcl
