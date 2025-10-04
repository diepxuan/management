#!/usr/bin/env python3

import sys
import os
import var.lib.os as d_os
from var.lib.registry import register_command
from rich.console import Console
from rich.table import Table


@register_command
def d_vm_info():
    """Display VM Information"""

    print("VM Information:")
    console = Console()
    table = Table(
        # title="\n[bold yellow]Các lệnh có sẵn[/bold yellow]",
        show_header=False,  # <-- TẮT tiêu đề cột
        box=None,  # <-- TẮT tất cả các đường viền
        padding=(
            0,
            2,
            0,
            0,
        ),  # <-- (top, right, bottom, left) - Chỉ thêm padding bên phải cột lệnh
    )
    table.add_row("Hostname", d_os._os_distro())
    table.add_row("IP Address", d_os._os_distro())
    table.add_row("DISTRIB", d_os._os_distro())
    table.add_row("OS", d_os._os_codename())
    table.add_row("RELEASE", d_os._os_release())
    table.add_row("ARCHITECTURE", d_os._os_architecture())

    # In bảng ra console
    console.print(table)


def d_vm_install_qemu_guest_agent():
    print("Installing qemu-guest-agent...")
    # Here you would add the actual installation logic
    print("qemu-guest-agent installed.")


# CSRF_TOKEN=

# d_vm:sync() {
#     [[ "$1" == "--help" ]] &&
#         echo "Sync VM Information" &&
#         return
#     d_vm_sync_doing=true
#     _vm:sync:ip_address $@
#     d_vm_sync_doing=false
# }

# _vm:sync:ip_address() {
#     _tolen=3ccbb8eb47507c42a3dfd2a70fe8e617509f8a9e4af713164e0088c715d24c83
#     _api=https://dns.diepxuan.io.vn/api
#     _domain=diepxuan.corp
#     _hostName=$(d_host:name)
#     # _fullName=$(d_host:fullname)
#     _fullName=${1:-$(d_host:fullname)}
#     _url_get="$_api/zones/records/get?token=$_tolen&domain=$_fullName&zone=$_domain&listZone=true"
#     _url_add="$_api/zones/records/add?token=$_tolen&domain=$_fullName&zone=$_domain&type=A&ipAddress="
#     _url_del="$_api/zones/records/delete?token=$_tolen&domain=$_fullName&zone=$_domain&type=A&ipAddress="

#     response=$(curl -s -w "%{http_code}" -o >(cat) $_url_get)
#     http_status=${response: -3}
#     response_body="${response:0:${#response}-3}"
#     status=$(echo $response_body | jq -r '.status')
#     body=$(echo $response_body | jq -r '.response')

#     # echo "HTTP Status Code: $http_status"
#     # echo "Status: $status"
#     # echo "Response Body: $body"
#     [[ "$http_status" == "200" ]] && {
#         [[ "$status" == "ok" ]] &&
#             old_ips=$(echo $body | jq -r '.records[] | select(.type == "A") | .rData.ipAddress')
#     }

#     old_ips=${old_ips[*]:-}
#     new_ips=${new_ips:-$(d_ip:local)}

#     # echo "Old ips: $old_ips"
#     # echo "New ips: $new_ips"

#     # Loại bỏ các IP trong old_ips không có trong new_ips
#     for old_ip in $old_ips; do
#         if [[ ! $new_ips =~ $old_ip ]]; then
#             # echo "Removing IP: $old_ip"
#             response=$(curl -s -w "%{http_code}" -o >(cat) ${_url_del}${old_ip})
#             http_status=${response: -3}
#             if [[ $http_status == 200 ]]; then
#                 response_body="${response:0:${#response}-3}"
#                 status=$(echo $response_body | jq -r '.status' 2>/dev/null)
#                 body=$(echo $response_body | jq -r '.response' 2>/dev/null)
#             # echo $response_body
#             fi
#         fi
#     done

#     # Thêm các IP trong new_ips không có trong old_ips
#     for new_ip in $new_ips; do
#         if [[ ! $old_ips =~ $new_ip ]]; then
#             # echo "Adding IP: $new_ip"
#             response=$(curl -s -w "%{http_code}" -o >(cat) ${_url_add}${new_ip})
#             http_status=${response: -3}
#             if [[ $http_status == 200 ]]; then
#                 response_body="${response:0:${#response}-3}"
#                 status=$(echo $response_body | jq -r '.status' 2>/dev/null)
#                 body=$(echo $response_body | jq -r '.response' 2>/dev/null)
#                 # echo $response_body
#             fi
#         fi
#     done

# }

# _vm:command() {
#     while read -r vm_cmd; do
#         $vm_cmd
#     done < <(echo $@ | jq -r '.vm.commands[]')
# }

# --isenabled() {
#     echo '1'
# }

# if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
#     "$@"
# fi
