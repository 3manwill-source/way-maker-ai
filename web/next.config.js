const { basePath, assetPrefix } = require('./utils/var-basePath')
const { codeInspectorPlugin } = require('code-inspector-plugin')
const withMDX = require('@next/mdx')({
  extension: /\.mdx?$/,
  options: {
    remarkPlugins: [],
    rehypePlugins: [],
  },
})

// the default url to prevent parse url error when running jest
const hasSetWebPrefix = process.env.NEXT_PUBLIC_WEB_PREFIX
const port = process.env.PORT || 3000
const locImageURLs = !hasSetWebPrefix ? [new URL(`http://localhost:${port}/**`), new URL(`http://127.0.0.1:${port}/**`)] : []
const remoteImageURLs = [hasSetWebPrefix ? new URL(`${process.env.NEXT_PUBLIC_WEB_PREFIX}/**`) : '', ...locImageURLs].filter(item => !!item)

/** @type {import('next').NextConfig} */
const nextConfig = {
  basePath,
  assetPrefix,
  webpack: (config, { dev, isServer }) => {
    // Add the code inspector plugin
    config.plugins.push(codeInspectorPlugin({ bundler: 'webpack' }))
    
    // Fix for Windows path handling
    if (!isServer) {
      config.resolve = config.resolve || {};
      config.resolve.fallback = config.resolve.fallback || {};
      
      // Normalize path separators for Windows
      const originalModuleResolver = config.resolve.alias?.['module'] || null;
      if (originalModuleResolver) {
        config.resolve.alias['module'] = originalModuleResolver.replace(/\\/g, '/');
      }
      
      // Set publicPath with forward slashes
      config.output.publicPath = `/_next/`;
    }
    
    return config;
  },
  productionBrowserSourceMaps: false,
  pageExtensions: ['ts', 'tsx', 'js', 'jsx', 'md', 'mdx'],
  images: {
    remotePatterns: remoteImageURLs.map(remoteImageURL => ({
      protocol: remoteImageURL.protocol.replace(':', ''),
      hostname: remoteImageURL.hostname,
      port: remoteImageURL.port,
      pathname: remoteImageURL.pathname,
      search: '',
    })),
  },
  experimental: {
    // Remove any experimental features that might cause issues
  },
  eslint: {
    ignoreDuringBuilds: true,
    dirs: ['app', 'bin', 'config', 'context', 'hooks', 'i18n', 'models', 'service', 'test', 'types', 'utils'],
  },
  typescript: {
    ignoreBuildErrors: true,
  },
  reactStrictMode: true,
  async redirects() {
    return [
      {
        source: '/',
        destination: '/apps',
        permanent: false,
      },
    ]
  },
  output: 'standalone',
}

module.exports = withMDX(nextConfig)