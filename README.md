# BiometricSolutionsCase

![Architecture overview](https://github.com/user-attachments/assets/8256508b-4c78-4a69-ba93-48117632d0ed)


### **View Architecture**
- **CameraView**: Main screen with full-screen camera and capture button
- **PermissionDeniedView**: Blocking view when camera permissions aren't granted
- **PhotoResultView**: Modal presentation of captured photo with hair mask displayed on top and additional details/settings below.


## Implementation Details

### 1. **Permissions Handling**
- Check camera permissions on app launch
- Show blocking view with "Grant Permission" button if denied
- Use async/await to update UI based on permission status

### 2. **Camera Implementation**
- Full-screen camera using AVCaptureSession
- Custom camera preview with capture button
- Proper session management and cleanup

### 3. **Hair Mask Extraction**
- Use Vision framework's AVSemanticSegmentationMatte
- Resize hair mask to fit original photo
- Create overlay mask for display
