let GitLab = https://gitlab.homotopic.tech/dhall/gitlab/-/raw/789b1d08cdf797cfa0e3b4ab2695fdba1e8de8e3/package.dhall

in  GitLab.Top.toJSON GitLab.stack-pipeline
