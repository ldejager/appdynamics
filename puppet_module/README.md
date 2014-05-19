AppDynamics Puppet Module


Class is instantiated via a host defintion or puppet ENC.

* class { 'appdynamics': version => '3.7.15-0', appgroup => 'group' }

The templates referred to in the init.pp are the standard configuration files, which have some spesific environment variables set via puppets ruby syntax, i.e.

* <tier-name><%= @system_role  %></tier-name>

Deployment is done via an RPM which is built using FPM from the tarballs provided by AppDynamics i.e.

* fpm -s dir -t rpm -n appdynamics -v 3.7.15 --iteration 0 --description "AppDynamics Application and Machine Agent" -a all opt/ etc/
