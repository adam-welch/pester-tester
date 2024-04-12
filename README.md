# pester-tester

## Description
Simple playground for me to test using pester as a unit test framework for terraform json plan files. I have found using terratest for testing against the json plan file a bit of chore as I need to setup structs etc to marshall the json which isn't difficult but is a pain and it's far simpler to do and maintain in powershell.

I also have been bitten when doing this using the hashicorp terraform plan way on the Microsoft site, https://learn.microsoft.com/en-us/azure/developer/terraform/test-modules-using-terratest, as needed to use dep to pull the dependecies which in turn sent antivirus software all over the place with some of the files being pulled down, like bomb.zip :( so this keeps it more lightweight for my use case.

I will turn the powershell functions in to a module at some point also, but need to make my powershell a bit more robust first.

## Shout Out
Everywhere I find useful examples of either testing, pester etc which I may or may not use a part of I will put a mention here"

- https://github.com/actions/runner-images - makes extensive use of pester when building the ADO\ github actions agents
