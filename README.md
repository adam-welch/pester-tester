# pester-tester

## Description
Simple playground for me to test using pester as a unit test framework for terraform json plan files. I have found using terratest for testing against the json plan file a bit of chore as I need to setup structs etc to marshall the json which isn't difficult but is a pain and it's far simpler to do and maintain in powershell.

I also have beenb bitten when doing this the using the hashicorp terraform plan way as needed to use dep to pull the dependecies which in turn sent antivirus software all over the place with some of the files being pulled down, like bomb.zip :( so this keeps it more lightweight for my use case.
