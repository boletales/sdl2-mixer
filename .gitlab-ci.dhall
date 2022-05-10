let Prelude =
        env:DHALL_PRELUDE
      ? https://raw.githubusercontent.com/dhall-lang/dhall-lang/v20.1.0/Prelude/package.dhall
          sha256:26b0ef498663d269e4dc6a82b0ee289ec565d683ef4c00d0ebdd25333a5a3c98

let Item = { description : Text, name : Text, type : Text }

let Attr
    : ∀(x : Type) → Type
    = λ(x : Type) → { mapKey : Text, mapValue : x }

let Step = { script : List Text }

let toStep
    : ∀(id : Text) → ∀(prefix : Text) → ∀(x : Attr Item) → Attr Step
    = λ(id : Text) →
      λ(prefix : Text) →
      λ(x : Attr Item) →
        { mapKey = id
        , mapValue.script = [ "nix build -L .#${prefix}.${x.mapKey}" ]
        }

let input = env:INPUT

let checks =
      Prelude.List.map
        (Attr Item)
        (Attr Step)
        (λ(x : Attr Item) → toStep "Check ${x.mapKey}" "checks.x86_64-linux" x)
        (toMap input.checks.x86_64-linux : List (Attr Item))

let packages =
      Prelude.List.map
        (Attr Item)
        (Attr Step)
        ( λ(x : Attr Item) →
            toStep "Package ${x.mapKey}" "packages.x86_64-linux" x
        )
        (toMap input.packages.x86_64-linux : List (Attr Item))

let devShell
    : Attr Step
    = { mapKey = "Build devShell"
      , mapValue.script = [ "nix build -L .#devShell.x86_64-linux" ]
      }

in  checks # packages # [ devShell ]
