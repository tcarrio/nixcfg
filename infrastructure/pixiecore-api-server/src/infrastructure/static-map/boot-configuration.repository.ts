import type { BootConfiguration } from "../../domain/boot-configuration.js";
import type { BootConfigurationRepository } from "../../domain/boot-configuration.repository.js";
import type { MAC } from "../../domain/mac.value-object.js";

const MAC_MAPPING: BootConfigurationMacMapping = new Map<string, BootConfiguration>([
  // Include static mappings here.
  // e.g. ['00-00-00-00-00-00', {...}]
]) 

export type BootConfigurationMacMapping = Map<string, BootConfiguration>;

export class StaticMapBootConfigurationRepository implements BootConfigurationRepository {
  constructor(private readonly mapping: BootConfigurationMacMapping) {}

  static forConstMapping() {
    return new this(MAC_MAPPING);
  }

  findByMAC(macAddress: MAC) {
    return this.mapping.get(macAddress.toString()) ?? null;
  }
}