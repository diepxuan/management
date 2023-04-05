# 0.0.11

- VM management
  - new model `\App\Models\Sys\Env\Domain`
  - change primary key to `vm_id`

# 0.0.10

- FUTURE
  - use bootstrap icon
  - new `parent` attribute
  - set `parent` for vm
  - tree view in VMs index

# 0.0.9

- FUTURE
  - new attribute `version` for `VmModel`
  - check `ductnd` version of Vm clients

# 0.0.8

- VM dashboard
  - delete old/error Vm
  - dis/en Vm to config from server

# 0.0.7

- VM dashboard
  - new `route`
  - show Vms info
  - new link into left navbar
- ISSUES
  - `html_entity_decode` etc data

# 0.0.6

- Vm dashboard
  - new `Admin/Vm` Controller
  - new `Admin/Vm` Model

# 0.0.5

- Show VMs info into dashboard
  - list VM name and hosts
- SECURITY CSRF_TOKEN for Vm clients
- Frontend
  - top narbar
  - left narbar
  - vm client layout

# 0.0.4

- Manegement VMs
  - create `VmController`
  - New model `Vm`
  - create table `vms`
  - receiver vm info
  - save info into table `vms`
- Home navbar
  - logo
  - home link
- `EnvController` resource to get system env config

# 0.0.3

- build js and css use `laravel-vite-plugin`
  - use bootstrap css and js

# 0.0.2

- create admin controller
  - create layouts
  - create admin layout
  - create home page
- add favicon icons
- clear route cache for dev

# 0.0.1

- FUTURE:
  - get env variable to controller
  - load `env` from base
  - add `config/debugbar.php`
  - prepare add debugbar to providers
  - create route `etc` to load `sys/env` from base
  - pull `env` config from github url
