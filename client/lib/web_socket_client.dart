import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:redux/redux.dart';
import 'package:flet_view/protocol/add_page_controls_payload.dart';
import 'package:flet_view/protocol/app_become_inactive_payload.dart';
import 'package:flet_view/protocol/append_control_props_request.dart';
import 'package:flet_view/protocol/clean_control_payload.dart';
import 'package:flet_view/protocol/page_controls_batch_payload.dart';
import 'package:flet_view/protocol/page_event_from_web_request.dart';
import 'package:flet_view/protocol/remove_control_payload.dart';
import 'package:flet_view/protocol/replace_page_controls_payload.dart';
import 'package:flet_view/protocol/session_crashed_payload.dart';
import 'package:flet_view/protocol/signout_payload.dart';
import 'package:flet_view/protocol/update_control_props_payload.dart';
import 'package:flet_view/protocol/update_control_props_request.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'protocol/message.dart';
import 'actions.dart';
import 'protocol/register_webclient_request.dart';
import 'protocol/register_webclient_response.dart';

WebSocketClient ws = WebSocketClient();

class WebSocketClient {
  WebSocketChannel? _channel;
  String _serverUrl = "";
  Store? _store;
  bool _connected = false;

  connect({required String serverUrl, required Store store}) async {
    _serverUrl = serverUrl;
    _store = store;

    debugPrint("Connecting to WebSocket server $serverUrl...");
    try {
      _channel = WebSocketChannel.connect(Uri.parse(_serverUrl));
      debugPrint("Connected to WebSocket server");
      _connected = true;
      _channel!.stream.listen(_onMessage, onDone: () async {
        debugPrint("WS stream closed");
      }, onError: (error) async {
        debugPrint("WS stream error $error");
      });
      debugPrint("Started listening for WS messages");
    } catch (e) {
      debugPrint("WebSocket connection error: $e");
    }
  }

  registerWebClient(
      {required String pageName,
      String? pageHash,
      String? winWidth,
      String? winHeight,
      String? sessionId}) {
    send(Message(
        action: MessageAction.registerWebClient,
        payload: RegisterWebClientRequest(
            pageName: pageName,
            pageHash: pageHash,
            winWidth: winWidth,
            winHeight: winHeight,
            sessionId: sessionId)));
  }

  pageEventFromWeb(
      {required String eventTarget,
      required String eventName,
      required String eventData}) {
    send(Message(
        action: MessageAction.pageEventFromWeb,
        payload: PageEventFromWebRequest(
            eventTarget: eventTarget,
            eventName: eventName,
            eventData: eventData)));
  }

  updateControlProps({required List<Map<String, String>> props}) {
    send(Message(
        action: MessageAction.updateControlProps,
        payload: UpdateControlPropsRequest(props: props)));
  }

  _onMessage(message) {
    debugPrint("WS message: $message");
    final msg = Message.fromJson(json.decode(message));
    switch (msg.action) {
      case MessageAction.registerWebClient:
        _store!.dispatch(RegisterWebClientAction(
            RegisterWebClientResponse.fromJson(msg.payload)));
        break;
      case MessageAction.appBecomeInactive:
        _store!.dispatch(AppBecomeInactiveAction(
            AppBecomeInactivePayload.fromJson(msg.payload)));
        break;
      case MessageAction.sessionCrashed:
        _store!.dispatch(
            SessionCrashedAction(SessionCrashedPayload.fromJson(msg.payload)));
        break;
      case MessageAction.signout:
        _store!.dispatch(SignoutAction(SignoutPayload.fromJson(msg.payload)));
        break;
      case MessageAction.addPageControls:
        _store!.dispatch(AddPageControlsAction(
            AddPageControlsPayload.fromJson(msg.payload)));
        break;
      case MessageAction.appendControlProps:
        _store!.dispatch(AppendControlPropsAction(
            AppendControlPropsPayload.fromJson(msg.payload)));
        break;
      case MessageAction.updateControlProps:
        _store!.dispatch(UpdateControlPropsAction(
            UpdateControlPropsPayload.fromJson(msg.payload)));
        break;
      case MessageAction.replacePageControls:
        _store!.dispatch(ReplacePageControlsAction(
            ReplacePageControlsPayload.fromJson(msg.payload)));
        break;
      case MessageAction.cleanControl:
        _store!.dispatch(
            CleanControlAction(CleanControlPayload.fromJson(msg.payload)));
        break;
      case MessageAction.removeControl:
        _store!.dispatch(
            RemoveControlAction(RemoveControlPayload.fromJson(msg.payload)));
        break;
      case MessageAction.pageControlsBatch:
        _store!.dispatch(PageControlsBatchAction(
            PageControlsBatchPayload.fromJson(msg.payload)));
        break;
      default:
    }
  }

  send(Message message) {
    if (_channel != null) {
      final m = json.encode(message.toJson());
      debugPrint("Send: $m");
      _channel!.sink.add(m);
    }
  }

  close() {
    if (_channel != null && _connected) {
      _channel!.sink.close();
    }
  }
}
