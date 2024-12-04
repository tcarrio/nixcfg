import { ValidationError } from "./validation.error.js";

export class MAC {
  private static REGEX = /^([0-9a-f]{2}-){5}[0-9a-f]{2}$/;

  constructor(private readonly value: string) {
    this.validate(value);
  }

  validate(value: string) {
    if (!MAC.REGEX.test(value)) {
      throw new ValidationError('Invalid MAC address');
    }
  }

  toString(): string {
    return this.value;
  }
}