import { BootConfigurationSchema, type BootConfiguration } from "../../domain/boot-configuration.js";
import type { BootConfigurationRepository } from "../../domain/boot-configuration.repository.js";
import * as fs from 'node:fs/promises';
import { IdentifiableSchema, type Identifiable } from "../../domain/identifiable.js";
import { z } from "zod";
import { StaticMapBootConfigurationRepository, type BootConfigurationMacMapping } from "../static-map/boot-configuration.repository.js";

const RawMacBootConfigurationMappingSchema = z.object({
  bootConfigurations: z.array(z.intersection(IdentifiableSchema, BootConfigurationSchema)),
  macAddressMappings: z.map(z.string(), z.string()),
})

type RawMacBootConfigurationMapping = z.infer<typeof RawMacBootConfigurationMappingSchema>;

export class JsonFileBootConfigurationRepositoryFactory {
  constructor(private readonly filepath: string) {}

  async create(): Promise<BootConfigurationRepository> {
    try {
      const buffer = await fs.readFile(this.filepath);

      const content = JSON.parse(buffer.toString('utf-8'));

      const validatedRawMapping = RawMacBootConfigurationMappingSchema.parse(content);

      return new StaticMapBootConfigurationRepository(this.toMap(validatedRawMapping));
    } catch (err) {
      throw new Error('Failed to create boot configuration', {
        cause: err,
      });
    }
  }

  private toMap(content: RawMacBootConfigurationMapping): BootConfigurationMacMapping {
    const configMap = new Map<string, BootConfiguration>();
    const bootConfigMapping: BootConfigurationMacMapping = new Map();

    for (const {id, ...config} of content.bootConfigurations) {
      configMap.set(id, config);
    }

    for (const [mac, configId] of content.macAddressMappings) {
      if (configMap.has(configId)) {
        bootConfigMapping.set(mac, configMap.get(configId)!);
      }
    }

    return bootConfigMapping;
  }
}