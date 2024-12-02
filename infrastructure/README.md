# infrastructure

Defines various resources that are hosted on cloud providers via **[OpenTofu]**.

## Laundry list

Don't use vanilla Terraform/OpenTofu.

You can quickly reach the limits of Terraform if you aren't implementing a Terraform provider explicitly for various functionality. How I am using the module system for parameterized Nix builds and Wrangler interactions has begun to reach these. 

Alternatives?

- **Use Terragrunt**. [Terragrunt] builds upon Terraform and provides more enhanced capabilities, explicit modules and dependency definitions, and enhanced cross-module interoperability.
- **Use Terranix**. [Terranix] processes Nix expressions and generates [Terraform JSON] configuration files, which can then be applied by a *Terraform-compatible* CLI like **OpenTofu**.

### Terragrunt

Terragrunt builds on useful concepts such as [directed-acyclic graphics (DAGs)][DAG] for deploying a stack of units. It also provides enhancements over Terraform that allow you to compose configurations and environments more easily, with documentation for [DRY backend](https://terragrunt.gruntwork.io/docs/getting-started/quick-start/#keep-your-backend-configuration-dry) and [provider configurations](https://terragrunt.gruntwork.io/docs/getting-started/quick-start/#keep-your-provider-configuration-dry). These would already provide some convenience for workarounds like the current `backends/cloudflare-r2.conf` file that is used in tandem with `tofu init`. Terragrunt also supports an **[auto-init](https://terragrunt.gruntwork.io/docs/features/auto-init/)** capability that removes this step!

The company backing Terragrunt is Gruntwork, and their primary offering is reusable Terragrunt modules primarily around AWS. I don't care for AWS much for personal projects, so I'm at a bit of an impasse of actually utilizing any of those.


### Terranix

This invests deeper in the Nix ecosystem, quite literally defining Terraform resources with Nix expressions instead of HCL. This is less natively operating inside Terraform and instead extracting certain capabilities into a declarative *and functional* language that can otherwise define the same constructs. Where you might have hit a limit with Terraform's native capabilities (e.g. meta-properties like `depends_on` not being compatible with Terraform `module`s), you could move an entire project definition into Nix definition, utilize the Nix module system where it fits, or functions where it may not. In the end, it's a JSON config that's similarly supported for Terraform `apply` commands.

There are no concepts of DAGs and ultimately the OpenTofu instance is utilized for applying the Terraform JSON configuration. The current areas of friction with Terraform will ultimately be overcome by shifting more logic into Nix. Where one current issue is `depends_on` with Terraform modules, you would instead bypass Terraform modules entirely and instead use Nix modules or functions. The final result being a single JSON file means all references will actually be static, so `depends_on` passed to underlying `resource` definitions will work.

<!-- References -->

[Terranix]: https://terranix.org/index.html
[OpenTofu]: https://opentofu.org/
[Terraform JSON]: https://developer.hashicorp.com/terraform/language/syntax/json
[Terragrunt]: https://terragrunt.gruntwork.io/
[DAG]: https://en.wikipedia.org/wiki/Directed_acyclic_graph