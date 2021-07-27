local img = app.activeCel.image
print(tostring(img.spec.width))
img.spec.width = img.spec.width * 2
print(tostring(img.spec.width))