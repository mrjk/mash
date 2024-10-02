#!/bin/bash

# From: https://gist.github.com/ipedrazas/2c93f6e74737d1f8a791?permalink_comment_id=3704504#gistcomment-3704504

parse () {

  local CURRENT=$(
    docker ps -q |
      xargs -n 1 docker inspect \
      --format '{{ .Name }};{{range $key, $value := .NetworkSettings.Networks}}{{ $key }},{{.IPAddress}};{{end}}' |
      sed 's@^/@@' 
    )
  
  # Loop over each entries
  while IFS=';' read name ip_list ; do
    for ip in ${ip_list//;/ }; do
      printf "%s\t%s\n" "$ip" "$name"
    done
  done <<<"$CURRENT"
}

render () {

  local last_net=''
  while read -s line; do
    net_name=${line%%,*}
    net_info=${line#*,}

    # Show title section
    [[ "$last_net" == "$net_name" ]] || {
      printf "%s:\n" "$net_name"
      last_net=$net_name
    }

    # Show entry
    printf "\t%s\n"  "$net_info"
  done <<<"$(parse | sort -h)"
}

render

#exit 
#
#function dip() {
#  _print_container_info() {
#      local container_id
#      local container_ports
#      local container_ip
#      local container_name
#      container_id="${1}"
#
#      container_ports=( $(docker port "$container_id" | grep -o "0.0.0.0:.*" | cut -f2 -d:) )
#      container_name="$(docker inspect --format "{{ .Name }}" "$container_id" | sed 's/\///')"
#      container_ip="$(docker inspect --format "{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}" "$container_id")"
#      printf "%-13s %-40s %-20s %-80s\n" "$container_id" "$container_name" "$container_ip" "${container_ports[*]}"
#  }
#
#  local container_id
#  container_id="$1"
#  printf "%-13s %-40s %-20s %-80s\n" 'Container Id' 'Container Name' 'Container IP' 'Container Ports'
#  if [ -z "$container_id" ]; then
#      local container_id
#      docker ps -a --format "{{.ID}}" | while read -r container_id ; do
#    _print_container_info  "$container_id"
#      done
#  else
#      _print_container_info  "$container_id"
#  fi
#}
#
#dip
