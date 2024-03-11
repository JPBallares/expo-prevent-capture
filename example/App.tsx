import * as ExpoPreventCapture from "expo-prevent-capture";
import { Platform, StyleSheet, Text, View } from "react-native";

export default function App() {
  if (Platform.OS === "ios") {
    ExpoPreventCapture.enableSecureView(); //This function blocks the Screen share/Recording and taking screenshot for iOS devices.
  }

  ExpoPreventCapture.addScreenshotListener(() => {
    console.log("Screenshot taken!");
  });

  return (
    <View style={styles.container}>
      <Text>This page should not allow screenshots.</Text>
      <Text>This page should not allow screenshots.</Text>
      <Text>This page should not allow screenshots.</Text>
      <Text>This page should not allow screenshots.</Text>
      <Text>This page should not allow screenshots.</Text>
      <Text>This page should not allow screenshots.</Text>
      <Text>This page should not allow screenshots.</Text>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: "#fff",
    alignItems: "center",
    justifyContent: "center",
  },
});
