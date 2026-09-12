import { Theme as BaseTheme } from "../theme/Theme"

declare module "@emotion/react" {
  // eslint-disable-next-line @typescript-eslint/no-empty-object-type
  export interface Theme extends BaseTheme {}
}
