{ pkgs, lib, config, ... }:
let
  inherit (pkgs) writeShellApplication;

  cfg = config.oxc.console.aws;

  awsCli = if cfg.useNixPackage then "${pkgs.awscli2}/bin/aws" else "aws";

  aws-sso = writeShellApplication {
    name = "aws-sso";
    text = ''
      #!/bin/sh
      ${awsCli} sso login
    '';
  };

  aws-ensure-login = writeShellApplication {
    name = "aws-ensure-login";
    text = ''
      #!/bin/sh
      if ! ${awsCli} sts get-caller-identity >/dev/null ; then
            echo "Doesnt look like you're logged into AWS SSO"
            ${aws-sso}
        fi
    '';
  };

  aws-list-accounts = writeShellApplication {
    name = "aws-list-accounts";
    text = ''
      #!/bin/sh
      ${awsCli} organizations list-accounts | ${pkgs.jq}/bin/jq '[.Accounts[] | {Name, Id, Arn}]' | ${pkgs.jtbl}/bin/jtbl
    '';
  };

  aws-ecr-login = writeShellApplication {
    name = "aws-ecr-login";
    text = ''
      #!/bin/bash

      region="''${AWS_REGION:-us-east-1}"

      if [ -z "''${AWS_PROFILE}" ]; then
        echo "Missing AWS_PROFILE! Please set the AWS_PROFILE environment variable."
        exit 1
      fi

      ${aws-ensure-login}/bin/aws-ensure-login

      # We need to check the versions of docker and aws cli here because of
      # a change to the docker email flag in recent versions. It isn't compatible
      # with older versions of the aws cli. See the below for details:

      if ${awsCli} --version | grep -qF 'aws-cli/2'; then
          ${awsCli} ecr get-login-password --region "''${region}" \
          | docker login --username AWS --password-stdin "''$(${awsCli} sts get-caller-identity | ${pkgs.jq}/bin/jq -r .Account).dkr.ecr.''${region}.amazonaws.com"
      else
          eval "''$(${awsCli} ecr get-login --region "''${region}" --no-include-email)"
      fi
    '';
  };
in
{
  options.oxc.console.aws = {
    enable = lib.mkEnableOption "Enable AWS CLI utilities";
    useNixPackage = lib.mkEnableOption "Utilize the Nix package for AWS CLI in utilities";
  };

  config = lib.mkIf cfg.enable {
    home.packages = [aws-sso aws-list-accounts aws-ecr-login]
      ++ (with pkgs; [jq jtbl ])
      ++ (if config.oxc.console.aws.useNixPackage then [pkgs.awscli2] else []);
  };
}
