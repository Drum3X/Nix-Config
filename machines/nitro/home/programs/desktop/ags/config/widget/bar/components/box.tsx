const WidgetBox = ({ ...rest }: JSX.IntrinsicElements["box"]) => {
    const content = Array.isArray(rest.children) && rest.children.length === 1
        ? rest.child
        : rest.children;

    return (
        <box
            cssClasses={["WidgetBox"]}
            {...rest}
        >
            {content}
        </box>
    )
}

export default WidgetBox;