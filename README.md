This repository contains a test case to showcase conftest blowing up the memory consumption
when using a large terraform plan json file(>=1Mb) and a complex rego
framework(ie. [regula](https://github.com/fugue/regula)). The outcome is
`contest test` runs up the memory to several GBs. 

# Pre-requisites

* Conftest binary
* Terraform Cli binary. I'm using 0.15.7

# Steps to reproduce

I already included `regula` and example `tfplan.json` to demonstrate the issue. 
Just run `conftest -p policy tfplan.json` it will run for a good 20s and if you
monitor you memory consumption it will blow up to over 2GB.

If you wish to create a fresh tf plan and download latest regula you can run
`make setup`. This will require AWS access to create a mock plan. 
 
