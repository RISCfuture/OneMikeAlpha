declare module 'config/secrets.js' {
  interface Secrets {
    mapboxAccessToken: string
    actionCableURL: string
  }
  const secrets: Secrets
  export default secrets
}

declare module '*.svg' {
  const path: string
  export default path
}
