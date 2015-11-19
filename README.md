# Openshift v3 tools

![Openshift icon](https://upload.wikimedia.org/wikipedia/en/3/3a/OpenShift-LogoType.svg)

## Overview

**Openshift v3 tools**, these tools is useful for who use Openshift v3.

### RHN Repository Backup Script
 This shell script is for backup openshift v3 repositories. In order to test openshift v3, you should sync the environment of client but you can always install latest packages via yum. Therefore, you have to archieve essential packages for each version formatted by ISO file. With those ISO file, you are able to configure specific version of openshift v3. 
 
 
 
 ```
  Usage : backup_repos.sh (with root user)
  
  Necessary parameters that you should notice:
  RHEL_VERSION - Installed RHEL OS version  (ex) 7.1 or 7.2
  OSE_VERSION - Installed Openshift version (ex) 3.0 or 3.1
  ISO_DIRECTORY - Directory contained archieved ISO files.
  CLEAR - If you want to archieve different version of Openshift(3.0 -> 3.1), you should remove previous repositories. 
          Hence, you should set it to true.  
  IS_FIRST - If it is first time to run this script, you should set it to true.
             This will register your system to rhn-manager, enable repositories and create some folders. 
             Once you run it, you should set it to false.            
  USER - rhn login user id.(it should be changed when IS_FIRST set to true)
  PASSWORD - rhn login user password.(it should be changed when IS_FIRST set to true)
```

License
---
---
Licensed under the Apache License, Version 2.0

*Free Software*
