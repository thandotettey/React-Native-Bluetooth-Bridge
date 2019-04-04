/**
 * Sample React Native App
 * https://github.com/facebook/react-native
 *
 * @format
 * @flow
 */

import React, {Component} from 'react';
import {Platform, StyleSheet, Text, View, NativeModules, Button} from 'react-native';

export default class App extends Component<Props> {

  startSession = () => {
    NativeModules.BluetoothManager.startSession();
  }

  endSession = () => {
    NativeModules.BluetoothManager.endSession();
  }

  startWaitingForConnection = () => {
    NativeModules.BluetoothManager.startWaitingForConnection();
  }

  stopWaitingForConnection = () => {
    NativeModules.BluetoothManager.stopWaitingForConnection();
  }

  connectAccessory = () => {
    NativeModules.BluetoothManager.connectAccessory();
  }

  sendStringToAccessory = () => {
    NativeModules.BluetoothManager.sendStringToAccessory();
  }

  checkAccessory = () => {
    NativeModules.BluetoothManager.checkAccessory();
  }


  render() {
    return (
      <View style={styles.container}>
        <Text style={styles.welcome}>Welcome to the Bluetooth App!</Text>
        <Button
          onPress={this.startSession}
          title="Start Session"
          color="#FF6347"
        />
        <Button
          onPress={this.endSession}
          title="End Session"
          color="#FF6347"
        />
        <Button
          onPress={this.startWaitingForConnection}
          title="Start Waiting for Connection"
          color="#FF6347"
        />
        <Button
          onPress={this.stopWaitingForConnection}
          title="Stop Waiting for Connection"
          color="#FF6347"
        />
        <Button
          onPress={this.connectAccessory}
          title="Connect Accessory"
          color="#FF6347"
        />
        <Button
          onPress={this.sendStringToAccessory}
          title="Send string to Accessory"
          color="#FF6347"
        />
        <Button
          onPress={this.checkAccessory}
          title="Check Accessory"
          color="#FF6347"
        />
      </View>
    );
  }
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#F5FCFF',
  },
  welcome: {
    fontSize: 20,
    textAlign: 'center',
    margin: 10,
  },
  instructions: {
    textAlign: 'center',
    color: '#333333',
    marginBottom: 5,
  },
});
