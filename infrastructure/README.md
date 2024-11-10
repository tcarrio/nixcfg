# infrastructure

Defines various resources that are hosted on cloud providers via **[terranix]** and **[OpenTofu]**.

**terranix** processes Nix expressions and generates [Terraform JSON] configuration files, which can then be applied by a *Terraform-compatible* CLI like **OpenTofu**.

<!-- References -->

[terranix]: https://terranix.org/index.html
[OpenTofu]: https://opentofu.org/
[Terraform JSON]: https://developer.hashicorp.com/terraform/language/syntax/json