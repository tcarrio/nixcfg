export interface BootConfiguration {
  /**
   * The URL of the kernel to boot.
   * 
   * This can be be an absolute path alone, without a scheme or hostname.
   */
  kernel: string;

  /**
   * URLs of initrds to load. The kernel will flatten all the initrds into a single filesystem.
   */
  initrd?: string[];

  /**
   * Commandline parameters for the kernel. The commandline is processed by Go's text/template
   * library. Within the template, a URL function is available that takes a URL and rewrites
   * it such that Pixiecore proxies the request.
   */
  cmdline?: string;

  /**
   * A message to display before booting the provided configuration. Note that displaying this
   * message is on a best-effort basis only, as particular implementations of the boot process
   * may not support displaying text.
   */
  message?: string;
}