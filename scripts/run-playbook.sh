#!/usr/bin/env bash
set -o errexit
set -o nounset

if [ "$#" -ne 2 ]; then
  echo 'Usage: ./run-playbook.sh <config_path>'
  exit 1
fi

config_path=${2}

# Construct Ansible extra_vars flags. If `config_path` is set, all files
# directly under the directory with extension `.yaml` or `.yml` will be added.
# The search for config files _will not_ descend into subdirectories.
extra_vars=(--extra-vars "@ansible/inventory/group_vars/defaults.yaml")
extra_vars+=( --extra-vars "@ansible/inventory/group_vars/aws_code_build.yaml")
for config_file in $( find -L "${config_path}" -maxdepth 1 -type f -a \( -name '*.yaml' -o -name '*.yml' \) | sort ); do
  extra_vars+=( --extra-vars "@${config_file}")
done

echo "Extra vars:"
echo "  ${extra_vars[*]}"

ANSIBLE_CONFIG=ansible/ansible.cfg \
  ansible-playbook "ansible/playbooks/${1}.yaml" \
  -i "localhost," \
  --module-path ansible/library/ \
  "${extra_vars[@]}"
