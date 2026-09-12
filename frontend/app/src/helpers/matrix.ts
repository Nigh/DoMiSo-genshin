import { mat4, vec3 } from "gl-matrix"

export const matrixFromTranslation = (x: number, y: number) => {
  const newMat = mat4.create()
  mat4.fromTranslation(newMat, vec3.fromValues(x, y, 0))
  return newMat
}
