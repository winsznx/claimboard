/** @type {import('next').NextConfig} */
const nextConfig = {
    reactStrictMode: true,
    transpilePackages: ['@claimboard/shared', '@claimboard/base-adapter', '@claimboard/stacks-adapter'],
};

export default nextConfig;
