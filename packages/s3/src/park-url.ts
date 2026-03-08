import { S3Client, GetObjectCommand } from "@aws-sdk/client-s3";
import { getSignedUrl } from "@aws-sdk/s3-request-presigner";
import { env } from "@wildlog/env/server";

// Garage does not support anonymous access to S3, so we need to create a pre-signed url using the aws sdk

export const getParkImageUrl = async (publicId: string, imageId: string) => {
  const s3 = new S3Client({
    region: "garage",
    endpoint: env.S3_URL,
    credentials: {
      accessKeyId: env.GARAGE_ACCESS_KEY,
      secretAccessKey: env.GARAGE_SECRET_KEY,
    },
    forcePathStyle: true, // Required for Garage to use path-style URLs -> url/bucket-name/key instead of bucket-name.url/key
  });

  // Generate a pre-signed URL for the image
  const command = new GetObjectCommand({
    Bucket: "park-images",
    Key: `${publicId}/${imageId}.jpg`,
  });

  const url = await getSignedUrl(s3, command, { expiresIn: 3600 }); // URL valid for 1 hour

  return url;
};
