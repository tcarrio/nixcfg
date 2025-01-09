import { z } from "zod";

export type Identifiable<T> = T & {
  id: string;
}

export const IdentifiableSchema = z.object({
  id: z.string(),
});