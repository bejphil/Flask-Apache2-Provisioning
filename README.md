# Provisioning Scripts for setting up Flask App on AWS EC2

## Introduction

Hosting a Python Flask app using apache2 is far more complicated than it
has any right to be. In particular getting apache2 `.conf` files to play nice with WSGI and
SSL encryption is a bit of a chore.

This projects walks through setting up a theoretical Flask program simply named `app`,
which is assumed to be deployed via AWS EC2.

## Deploying to AWS EC2

See the included [EC 2 set-up guide](ec2-setup.md) for a comprehensive walk-through
of how to set-up an example app on EC 2.
