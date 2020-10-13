with import <nixpkgs> { };

stdenv.mkDerivation rec {
  name = "et";
  env = buildEnv {
    name = name;
    paths = buildInputs;
  };

  buildInputs = [ python37 pipenv python37Packages.six python37Packages.pynvim nodejs ];

  # Set Environment Variables
  shellHook = ''
    SOURCE_DATE_EPOCH=$(date +%s) # required for python wheels

    local venv=$(pipenv --bare --venv &>> /dev/null)

    if [[ -z $venv || ! -d $venv ]]; then
      pipenv install --python 3.7 --dev &>> /dev/null
    fi

    export VIRTUAL_ENV=$(pipenv --venv)
    export PIPENV_ACTIVE=1
    export PYTHONPATH="$VIRTUAL_ENV/${python3.sitePackages}:$PYTHONPATH"
    export PATH="$VIRTUAL_ENV/bin:$PATH"

    which poetry || pip install poetry
  '';
}
