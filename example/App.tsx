import { StyleSheet, Text, View } from 'react-native';

import * as ExpoPreventCapture from 'expo-prevent-capture';

export default function App() {
  return (
    <View style={styles.container}>
      <Text>{ExpoPreventCapture.hello()}</Text>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#fff',
    alignItems: 'center',
    justifyContent: 'center',
  },
});
