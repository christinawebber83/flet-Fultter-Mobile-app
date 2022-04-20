from typing import Optional

from beartype import beartype

from flet.control import Control, InputBorder, OptionalNumber, PaddingValue, TextAlign
from flet.form_field_control import FormFieldControl
from flet.ref import Ref

try:
    from typing import Literal
except:
    from typing_extensions import Literal

TextInputType = Literal[
    None,
    "text",
    "multiline",
    "number",
    "phone",
    "datetime",
    "email",
    "url",
    "visiblePassword",
    "name",
    "streetAddress",
    "none",
]


class TextField(FormFieldControl):
    def __init__(
        self,
        ref: Ref = None,
        width: OptionalNumber = None,
        height: OptionalNumber = None,
        expand: int = None,
        opacity: OptionalNumber = None,
        visible: bool = None,
        disabled: bool = None,
        data: any = None,
        #
        # FormField specific
        #
        label: str = None,
        icon: str = None,
        border: InputBorder = None,
        content_padding: PaddingValue = None,
        filled: bool = None,
        hint_text: str = None,
        helper_text: str = None,
        counter_text: str = None,
        error_text: str = None,
        prefix: Control = None,
        prefix_icon: str = None,
        prefix_text: str = None,
        suffix: Control = None,
        suffix_icon: str = None,
        suffix_text: str = None,
        #
        # TextField Specific
        #
        value: str = None,
        keyboard_type: TextInputType = None,
        min_lines: int = None,
        max_lines: int = None,
        password: bool = None,
        can_reveal_password: bool = None,
        read_only: bool = None,
        text_align: TextAlign = None,
        on_change=None,
    ):
        FormFieldControl.__init__(
            self,
            ref=ref,
            width=width,
            height=height,
            expand=expand,
            opacity=opacity,
            visible=visible,
            disabled=disabled,
            data=data,
            #
            # FormField
            #
            label=label,
            icon=icon,
            border=border,
            content_padding=content_padding,
            filled=filled,
            hint_text=hint_text,
            helper_text=helper_text,
            counter_text=counter_text,
            error_text=error_text,
            prefix=prefix,
            prefix_icon=prefix_icon,
            prefix_text=prefix_text,
            suffix=suffix,
            suffix_icon=suffix_icon,
            suffix_text=suffix_text,
        )
        self.value = value
        self.keyboard_type = keyboard_type
        self.text_align = text_align
        self.min_lines = min_lines
        self.max_lines = max_lines
        self.read_only = read_only
        self.password = password
        self.can_reveal_password = can_reveal_password
        self.on_change = on_change

    def _get_control_name(self):
        return "textfield"

    # value
    @property
    def value(self):
        return self._get_attr("value", def_value="")

    @value.setter
    def value(self, value):
        self._set_attr("value", value)

    # keyboard_type
    @property
    def keyboard_type(self):
        return self._get_attr("keyboardType")

    @keyboard_type.setter
    @beartype
    def keyboard_type(self, value: TextInputType):
        self._set_attr("keyboardType", value)

    # text_align
    @property
    def text_align(self):
        return self._get_attr("textAlign")

    @text_align.setter
    @beartype
    def text_align(self, value: TextAlign):
        self._set_attr("textAlign", value)

    # min_lines
    @property
    def min_lines(self):
        return self._get_attr("minLines")

    @min_lines.setter
    @beartype
    def min_lines(self, value: Optional[int]):
        self._set_attr("minLines", value)

    # max_lines
    @property
    def max_lines(self):
        return self._get_attr("maxLines")

    @max_lines.setter
    @beartype
    def max_lines(self, value: Optional[int]):
        self._set_attr("maxLines", value)

    # read_only
    @property
    def read_only(self):
        return self._get_attr("readOnly", data_type="bool", def_value=False)

    @read_only.setter
    @beartype
    def read_only(self, value: Optional[bool]):
        self._set_attr("readOnly", value)

    # password
    @property
    def password(self):
        return self._get_attr("password", data_type="bool", def_value=False)

    @password.setter
    @beartype
    def password(self, value: Optional[bool]):
        self._set_attr("password", value)

    # can_reveal_password
    @property
    def can_reveal_password(self):
        return self._get_attr("canRevealPassword", data_type="bool", def_value=False)

    @can_reveal_password.setter
    @beartype
    def can_reveal_password(self, value: Optional[bool]):
        self._set_attr("canRevealPassword", value)

    # on_change
    @property
    def on_change(self):
        return self._get_event_handler("change")

    @on_change.setter
    def on_change(self, handler):
        self._add_event_handler("change", handler)
        if handler != None:
            self._set_attr("onchange", True)
        else:
            self._set_attr("onchange", None)
