class appdynamics::agent::install {
	
	Package {  schedule => always }

        package{ "appdynamics":
                ensure	=> "$appdynamics::version",
                provider => rpm,
                source 	=> "http://$repo_url/appdynamics-${appdynamics::version}.noarch.rpm",
                notify	=> Service["appd_machineagent"];
        }
}
