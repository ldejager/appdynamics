#!/usr/bin/env python
#
# AppDynamics Health Rule API Client
# 
# Export Health Rule configuration from a reference application to other controllers and/or applications.

import os
import re
import sys
import argparse
import requests
from ConfigParser import SafeConfigParser
from requests.auth import HTTPBasicAuth
import xml.etree.ElementTree as ET


class HealthRules(object):
    """
    Class for AppDynamics Health Rule exporting and importing using a RESTful API
    """

    CONFIG = os.path.dirname(os.path.abspath(__file__)) + '/config.ini'

    def __connect__(self, controller, path):
        """
        Connect to given controller and retrieve the requested URI
        """

        parser = SafeConfigParser()
        parser.read(self.CONFIG)

        username = parser.get(controller, 'account') + '@' + parser.get(controller, 'username')
        password = parser.get(controller, 'password')
        appdyurl = parser.get(controller, 'url')

        try:
            connect = requests.get(appdyurl+path, auth=HTTPBasicAuth(username, password))
            return connect
        except:
            print "There was an error retrieving the required information from the controller:\n\n"
            raise

    def __upload__(self, controller, path, filename):
        """
        Upload the exported Health Rules to given controller
        """

        parser = SafeConfigParser()
        parser.read(self.CONFIG)

        username = parser.get(controller, 'account') + '@' + parser.get(controller, 'username')
        password = parser.get(controller, 'password')
        appdyurl = parser.get(controller, 'url')

        try:
            files = {'file': open(filename, 'rb')}
            upload = requests.post(appdyurl+path, auth=HTTPBasicAuth(username, password), files=files)
            return upload
        except:
            print "There was an error submitting the configuration to the controller:\n\n"
            raise

    def __get_applications__(self, controller):
        """
        Get applications from controller
        """

        connect = self.__connect__(controller, '/controller/rest/applications')
        root = ET.fromstring(connect.text)

        app_ids = []

        for app in root.findall('application'):
            appid = app.find('id').text
            name = app.find('name').text
            if re.search('[a-zA-Z]{3}[0-9]{1}$', name):
                app_ids.append(appid)

        return app_ids

    def __get_application__(self, controller, src_app):
        """
        Get application from controller
        """

        connect = self.__connect__(controller, '/controller/rest/applications')
        root = ET.fromstring(connect.text)

        app_id = []

        for app in root.findall('application'):
            appid = app.find('id').text
            name = app.find('name').text
            if re.search(src_app+'$', name, re.IGNORECASE):
                app_id.append(appid)

        return str(app_id).strip('[]').strip("''")

    def __export_healthrule__(self, controller, src_app):
        """
        Export Health Rule
        """

        app_id = self.__get_application__(controller, src_app)
        connect = self.__connect__(controller, '/controller/healthrules/'+app_id)

        if not app_id:
            print "No ID found"
            sys.exit()
        else:
            print "Exporting Health Rules from %s" % src_app

            with open(src_app+'.xml', 'w') as fh:
                fh.write(connect.text)

            return connect.text

    def __get_tiers__(self, controller, apptier, tiername):
        """
        Get Tiers
        """

        connect = self.__connect__(controller, '/controller/rest/applications/'+apptier+'/tiers')
        root = ET.fromstring(connect.text)

        tiers = []

        for app in root.findall('tier'):
            name = app.find('name').text
            if re.search(tiername+'$', name, re.IGNORECASE):
                tiers.append(name)

        return tiers

    def __update_xml__(self, tiers, hrxml, dst_tier):
        """
        Update XML and write out new copy to disk
        """

        if not tiers:
            print "Tiers is empty, cannot continue:"
            sys.exit(1)

        dest_hrxml = hrxml.replace("REFERENCE-APPLICATION-"+dst_tier, tiers[0])

        root = ET.fromstring(dest_hrxml)

        jmx = root.findall(".//affected-entities-match-criteria/affected-jmx-match-criteria/components")
        infra = root.findall(".//affected-entities-match-criteria/affected-infra-match-criteria/application-components")
        custom = root.findall(".//critical-execution-criteria/policy-condition/metric-expression/metric-definition/entity")

        for jmx_component in jmx:
            jmx_component.clear
            for tier in tiers:
                ET.SubElement(jmx_component, 'application-component').text=tier
        for infra_component in infra:
            infra_component.clear
            for tier in tiers:
                ET.SubElement(infra_component, 'application-component').text=tier
        for custom_component in custom:
            custom_component.clear
            for tier in tiers:
                ET.SubElement(custom_component, 'application-component').text=tier

        ET.ElementTree(root).write("healthrules.xml")

    def __upload_healthrules__(self, controller, dst_app):
        """
        Upload Healthrules to given controller
        """

        upload = self.__upload__(controller, '/controller/healthrules/'+dst_app+'?overwrite=true', "healthrules.xml")
        print upload.text


if __name__ == '__main__':

    args_parse = argparse.ArgumentParser(prog='healthrules.py', usage='%(prog)s [src_controller] [src_app] '
                                                                      '[dst_controller] [dst_app] [dst_tier]')
    args_parse.add_argument('src_controller', help='Source controller to connect to, i.e. production1')
    args_parse.add_argument('src_app', help='Source application to copy from, i.e. APP1')
    args_parse.add_argument('dst_controller', help='Destination controller to connect to, i.e. production2')
    args_parse.add_argument('dst_app', help='Destination application to copy to, i.e. APP2')
    args_parse.add_argument('dst_tier', help='Destination tier i.e. TIER2')
    argument = args_parse.parse_args()

    hr = HealthRules()

    src_controller = argument.src_controller
    src_app = argument.src_app

    hrxml = hr.__export_healthrule__(src_controller, src_app)
    tiers = hr.__get_tiers__(argument.dst_controller, argument.dst_app, argument.dst_tier)

    hr.__update_xml__(tiers, hrxml, argument.dst_tier)
    hr.__upload_healthrules__(argument.dst_controller, argument.dst_app)
