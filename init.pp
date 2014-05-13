class appdynamics::core ($version,$appgroup,$site) {

	Class['appdynamics::core::agent::install'] -> Class['appdynamics::core::agent::config']
			
        class { "appdynamics::core::agent::install": }
        class { "appdynamics::core::agent::config": }
}

