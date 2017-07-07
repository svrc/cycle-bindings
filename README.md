# cycle-bindings
Unbinds and rebinds, or restarts apps with given CF service bindings.  Useful when you need to re-IP your services.

Prereqs:  the **CF CLI** logged in as an admin user; the **jq** command must also be installed.

**This command does not actually execute any CF commands, it just echos them to stdout.  This will allow you to track progress and debug services that don't rebind properly or apps that don't up.  Redirect the output to a file and then execute it.**

How to use:
```
rebind.sh [restart|rebind] [service offering name (default all)] > my_rebind_script.sh
chmod u+x ./my_rebind_script.sh
./my_rebind_script.sh
```
Docs:
- *Restart* will restart all apps that are bound to a service of a given name in the marketplace (or , default, all services)
- *Rebind* will unbind and rebind all apps that are bound to a service of a given name in the marketplace

# Examples

## Rebind all p-mysql instances
```
./rebind.sh rebind p-mysql > rebind_mysql.sh
chmod u+x ./rebind_mysql.sh 
./rebind_mysql.sh
```
## Restart all apps bound to p-mysql instances
```
./rebind.sh rebind p-mysql > restart_mysql.sh
chmod u+x ./restart_mysql.sh 
./restart_mysql.sh
```

Acknowledgements:  Hat tip to Dr. Nic's Delete all Services and bindings script which was the initial basis for this one https://github.com/cloudfoundry-community/delete-all-bindings-and-services/blob/master/bin/delete.sh
