export ANSIBLE_HOST_KEY_CHECKING=false

DOMAIN="lostcities.dev"

while [[ $# -gt 0 ]]; do
  case $1 in
    -n|-domain)
      DOMAIN="$2"
      shift; shift;
      ;;
    -d|-destroy)
      echo "Destroying..."
      cd ./initialize || exit;
      terraform destroy -var="domain=${DOMAIN}" -auto-approve
      cd ..;
      shift
      ;;
    -nuke)
      echo "Destroying..."
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
  retries=5
  n=0
  until [ "$n" -ge $retries ]
  do
    ansible-playbook "${@: 1}" -i ./inventory.ini && break
    n=$((n+1))
  done
}

terraform_retry

node tfstate.js ./initialize/terraform.tfstate > ./inventory.ini

ansible_retry ./provision/base-configure.yml
ansible_retry ./provision/frontend-playbook.yml
ansible_retry ./provision/nginx/nginx-playbook.yml --extra-vars "domain=${DOMAIN}"
ansible_retry ./provision/prometheus/prometheus-playbook.yml
