import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';

import '../actions.dart';
import '../models/app_state.dart';
import '../models/control.dart';
import '../protocol/update_control_props_payload.dart';
import '../web_socket_client.dart';
import 'create_control.dart';

enum LabelPosition { right, left }

class CheckboxControl extends StatefulWidget {
  final Control? parent;
  final Control control;
  final bool parentDisabled;

  const CheckboxControl(
      {Key? key,
      this.parent,
      required this.control,
      required this.parentDisabled})
      : super(key: key);

  @override
  State<CheckboxControl> createState() => _CheckboxControlState();
}

class _CheckboxControlState extends State<CheckboxControl> {
  bool? _value;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint("Checkbox build: ${widget.control.id}");

    String label = widget.control.attrString("label", "")!;
    LabelPosition labelPosition = LabelPosition.values.firstWhere(
        (p) =>
            p.name.toLowerCase() ==
            widget.control.attrString("labelPosition", "")!.toLowerCase(),
        orElse: () => LabelPosition.right);
    bool tristate = widget.control.attrBool("tristate", false)!;
    bool disabled = widget.control.isDisabled || widget.parentDisabled;

    return StoreConnector<AppState, Function>(
        distinct: true,
        converter: (store) => store.dispatch,
        builder: (context, dispatch) {
          debugPrint("Checkbox StoreConnector build: ${widget.control.id}");

          bool? value =
              widget.control.attrBool("value", tristate ? null : false);
          if (_value != value) {
            _value = value;
          }

          onChange(bool? value) {
            var svalue = value != null ? value.toString() : "";
            debugPrint(svalue);
            setState(() {
              _value = value;
            });
            List<Map<String, String>> props = [
              {"i": widget.control.id, "value": svalue}
            ];
            dispatch(UpdateControlPropsAction(
                UpdateControlPropsPayload(props: props)));
            ws.updateControlProps(props: props);
            ws.pageEventFromWeb(
                eventTarget: widget.control.id,
                eventName: "change",
                eventData: svalue);
          }

          var checkbox = Checkbox(
              value: _value,
              tristate: tristate,
              onChanged: !disabled
                  ? (bool? value) {
                      onChange(value);
                    }
                  : null);

          Widget result = checkbox;
          if (label != "") {
            var labelWidget = disabled
                ? Text(label,
                    style: TextStyle(color: Theme.of(context).disabledColor))
                : MouseRegion(
                    cursor: SystemMouseCursors.click, child: Text(label));
            result = GestureDetector(
                onTap: !disabled
                    ? () {
                        bool? newValue;
                        if (!tristate) {
                          newValue = !_value!;
                        } else if (tristate && _value == null) {
                          newValue = false;
                        } else if (tristate && _value == false) {
                          newValue = true;
                        }
                        onChange(newValue);
                      }
                    : null,
                child: labelPosition == LabelPosition.right
                    ? Row(children: [checkbox, labelWidget])
                    : Row(children: [labelWidget, checkbox]));
          }

          return constrainedControl(result, widget.parent, widget.control);
        });
  }
}
