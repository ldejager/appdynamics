# === Class: appdynamics
#
# Puppet class for appdynamics
#
# Leon de Jager (ldejager)
#
# === Parameters
#
# The following parameters needs to be passed to the class:-
#
# $version	- Version of the application that needs to be installed (RPM)
# $appgroup	- Group that the appdynamics installation directory needs to be set to
#
# === Examples
#
#  class { 'appdynamics':
#    version	=> '3.15.0',
#    appgroup	=> 'group'
#  }
#

class appdynamics ($version,$appgroup) {

	Class['appdynamics::agent::install'] -> Class['appdynamics::agent::config'] -> Class['appdynamics::agent::service']

	include appdynamics::agent::install
	include appdynamics::agent::config
	include appdynamics::agent::service

}
