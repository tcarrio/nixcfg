import type { BootConfiguration } from "../../domain/boot-configuration.entity.js";
import type { BootConfigurationRepository } from "../../domain/boot-configuration.repository.js";
import type { MAC } from "../../domain/mac.value-object.js";

const MAC_MAPPING = new Map<string, BootConfiguration>([
  // Include static mappings here.
  // e.g. ['00-00-00-00-00-00', {...}]
]) 

export class StaticMapBootConfigurationRepository implements BootConfigurationRepository {
  findByMAC(macAddress: MAC) {
    return MAC_MAPPING.get(macAddress.toString()) ?? null;
  }
}