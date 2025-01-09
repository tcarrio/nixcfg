import type { BootConfiguration } from "./boot-configuration.js";
import type { MAC } from "./mac.value-object.js";

export interface BootConfigurationRepository {
  findByMAC(macAddress: MAC): BootConfiguration|null;
}
