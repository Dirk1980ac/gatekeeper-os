# Gatekeeper OS

This is my custom build of Fedora Linux for router devices.  

## What you should know

There is no fancy WebUI for configuration, except for cockpit which
unfortunately lacks some important firewall configuration capabilities.

The image works well but you have to know how to use the command line because
cockpits NetworkManager plug-in does not cover FirewallD policies for example.

## Additional notes

- This is a work in progress ans has not yet been released.

- freeipa-client is installed into the image since I mostly work in Freeipa
environments and I want to log in with my global network wide credentials.  
  
Documentation will be added later on.
