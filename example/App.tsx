import * as ExpoPreventCapture from "expo-prevent-capture";
import { StyleSheet, Text, View } from "react-native";

export default function App() {
  ExpoPreventCapture.preventScreenCaptureAsync();

  return (
    <View style={styles.container}>
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
