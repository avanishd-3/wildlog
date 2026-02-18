import { pipeline } from "@huggingface/transformers";

// Create a feature-extraction pipeline
export const extractor = await pipeline("feature-extraction", "Xenova/all-MiniLM-L6-v2", {
  dtype: "fp16",
  device: "cpu",
});

export async function computeEmbedding(sentences: string[]) {
  const output = await extractor(sentences, { pooling: "mean", normalize: true });
  return output.tolist();
}
