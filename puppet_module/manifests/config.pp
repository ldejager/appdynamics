class appdynamics::agent::config {

        group { 'appdynamics':
                ensure  => present,
                gid     => 5900,
        }

        user { "appdynamics":
                ensure  	=> present,
                uid     	=> 5900,
                comment 	=> "AppDynamics",
                home    	=> "/opt/appdynamics",
                gid     	=> 5900,
                shell   	=> '/sbin/nologin',
                managehome      => true,
		require 	=> Group["appdynamics"],
        }

	file {
                '/opt/appdynamics':
                        ensure  => directory,
                        owner   => appdynamics,
                        group   => appdynamics,
                        require => [ Package['appdynamics'],
					User['appdynamics']
				]
			;
                '/opt/appdynamics/machineagent':
                        ensure  => directory,
                        owner   => appdynamics,
                        group   => appdynamics,
			recurse => true,
                        require => [ Package['appdynamics'],
                                        User['appdynamics']
                                ]
                        ;
                '/opt/appdynamics/appagent':
                        ensure  => directory,
                        owner   => appdynamics,
                        group   => $appgroup,
			mode    => 0664,
                        recurse => true,
                        require => [ Package['appdynamics'],
                                        User['appdynamics']
                                ]
                        ;
		'/opt/appdynamics/appagent/conf/controller-info.xml':
			content	=> template('appdynamics/appagent/controller-info.xml.erb'),
			ensure	=> file,
			owner	=> appdynamics,
			group	=> appdynamics,
			mode	=> 0644,
			require	=> Package["appdynamics"],
			notify  => Service["appdynamics_machineagent"],
			;
		'/opt/appdynamics/machineagent/conf/controller-info.xml':
			content => template('appdynamics/machineagent/controller-info.xml.erb'),
			ensure	=> file,
			owner	=> appdynamics,
			group	=> appdynamics,
			mode	=> 0644,
			require	=> Package["appdynamics"],
			notify	=> Service["appd_machineagent"],
			;
	}
}
