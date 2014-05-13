class appdynamics::core ($version,$appgroup,$site) {

	Class['appdynamics::core::agent::install'] -> Class['appdynamics::core::agent::config']
			
        class { "appdynamics::core::agent::install": }
        class { "appdynamics::core::agent::config": }
}

class appdynamics::core::agent::install {

        package{ "appdynamics":
                ensure	=> "$version",
                provider => rpm,
                source 	=> "http://$repo_url/appdynamics-${version}.noarch.rpm",
                notify	=> Service["appdynamics_machineagent"];
        }
}

class appdynamics::core::agent::config {

	Package {  schedule => always, }

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
			notify	=> Service["appdynamics_machineagent"],
			;
	}

	service { "appdynamics_machineagent":
		ensure		=> running,
		enable		=> true,
		status		=> "pgrep -f machineagent.jar",
	}
} 

