class appdynamics::agent::service {
	
	service { "appd_machineagent":
		ensure		=> running,
		enable		=> true,
		status		=> "pgrep -f machineagent.jar",
	}

}
