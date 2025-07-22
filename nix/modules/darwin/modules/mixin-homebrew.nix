_: {
  homebrew = {
    enable = true;

    taps = [ ];

    # the following sets up Homebrew to NEVER update implicitly
    # to update brew itself, use `brew upgrade`
    # to update brew packages, use `brew update`
    global.autoUpdate = false;
    onActivation.autoUpdate = false;
  };
}
